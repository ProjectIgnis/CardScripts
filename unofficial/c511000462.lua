--磁石の戦士マグネット・バルキリオン (Anime)
--Valkyrion the Magna Warrior (Anime)
--Updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,99785935,39256679,11549357)
	Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.splimit,nil,SUMMON_TYPE_FUSION)
end
s.material_setcode={0x66,0x2066}
s.listed_series={0x66,0x2066}
s.listed_names={99785935,39256679,11549357}
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.contactfilter(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL+REASON_FUSION)
end
