--ワーム・ヴォイド・ホール
--Worm Void Hole
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,s.fusfilter)
end
s.listed_names={160018001,160010025}
function s.fusfilter(c)
	return c:IsLevelBelow(9) and c:ListsCodeAsMaterial(160018001,160010025)
end