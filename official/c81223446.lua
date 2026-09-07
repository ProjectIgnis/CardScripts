--死魂融合
--Necro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion Monster from your Extra Deck, by banishing Fusion Materials mentioned on it from your GY face-down, but it cannot attack this turn
	local e1=Fusion.CreateSummonEff({
			handler=c,
			matfilter=aux.FALSE,
			extrafil=s.fextra,
			extratg=s.extratg,
			extraop=s.extraop,
			stage2=s.stage2}
		)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.matfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and aux.SpElimFilter(c)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.matfilter),tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil,tp)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.extraop(e,fc,tp,sg)
	local faceup,facedown=sg:Split(Card.IsFaceup,nil)
	if #faceup>0 then Duel.HintSelection(faceup) end
	if #facedown>0 then Duel.ConfirmCards(1-tp,facedown) end
	Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,fc,tp,sg,chk)
	if chk==1 then
		--It cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		fc:RegisterEffect(e1,true)
	end
end