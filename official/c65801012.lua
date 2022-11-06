--サイバネット・フュージョン
--Cynet Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),nil,s.fextra,s.extraop,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,LOCATION_EMZONE,0)==0 and not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local eg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter0(c)
	return c:IsLinkMonster() and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemove()
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
