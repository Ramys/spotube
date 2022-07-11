import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/LoaderShimmers/ShimmerPlaybuttonCard.dart';
import 'package:spotube/components/Playlist/PlaylistCard.dart';
import 'package:spotube/components/Playlist/PlaylistCreateDialog.dart';
import 'package:spotube/provider/SpotifyDI.dart';
import 'package:spotube/provider/queries.dart';

class UserPlaylists extends HookConsumerWidget {
  const UserPlaylists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final spotify = ref.watch(spotifyProvider);
    final query =
        useQuery(job: currentUserPlaylistsQueryJob, externalData: spotify);

    return Builder(
      builder: (context) {
        if (query.isLoading || !query.hasData) {
          return const Center(child: ShimmerPlaybuttonCard(count: 7));
        } else if (query.hasError) {
          const Text("Failure is the pillar of success");
        }
        Image image = Image();
        image.height = 300;
        image.width = 300;
        PlaylistSimple likedTracksPlaylist = PlaylistSimple();
        likedTracksPlaylist.name = "Liked Tracks";
        likedTracksPlaylist.type = "playlist";
        likedTracksPlaylist.collaborative = false;
        likedTracksPlaylist.public = false;
        likedTracksPlaylist.id = "user-liked-tracks";
        image.url =
            "https://t.scdn.co/images/3099b3803ad9496896c43f22fe9be8c4.png";
        likedTracksPlaylist.images = [image];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 20, // gap between adjacent chips
              runSpacing: 20, // gap between lines
              alignment: WrapAlignment.center,
              children: [
                const PlaylistCreateDialog(),
                PlaylistCard(likedTracksPlaylist),
                ...query.data!
                    .map((playlist) => PlaylistCard(playlist))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
