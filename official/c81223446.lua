--死魂融合
--Necro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon 1 fusion monster by banishing monsters from GY, face-down, as material
	local e1=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,s.extraop,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
function s.matfilter(c,e,tp,check_or_run)
	return aux.SpElimFilter(c) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--Cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end