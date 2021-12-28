--幽合－ゴースト・フュージョン
--Ghost Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat(aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE)),s.fextra,s.extraop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
local LOCATION_HAND_DECK_GRAVE=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND_DECK_GRAVE)<=1
end
function s.fextra(e,tp,mg)
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) and not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local eg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE+LOCATION_HAND_DECK_GRAVE,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter0(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND_DECK_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end