--ザ☆バーサス・フュージョン
--The Versus Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.fusfilter,aux.FALSE,s.fextra,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
s.listed_names={160012003}
function s.fusfilter(c)
	return c:ListsCodeAsMaterial(160012003)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0
end
function s.exfilter(c)
	if c:IsRace(RACE_DRAGON) and not c:IsCode(160012003) then return false end
	if c:IsLocation(LOCATION_MZONE) then return c:IsType(TYPE_NORMAL) end
	return true
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if #eg>0 then
		return eg,s.fcheck
	end
	return nil
end