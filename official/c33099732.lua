--超未来融合－オーバーフューチャー・フュージョン
--Over Future Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.exfilter(c,tp)
	return c.material and c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.tgfilter(c,fc)
	return c:IsCode(table.unpack(fc.material)) and c:IsAbleToGrave()
end
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local fusparams={handler=e:GetHandler(),fusfilter=s.ffilter,matfilter=aux.FALSE,
						extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Fusion.SummonEffTG(fusparams)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Fusion.SummonEffTG(fusparams)(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--Send 1 Fusion Material from your Deck to the GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cc=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if not cc then return end
		Duel.ConfirmCards(1-tp,cc)
		Duel.ShuffleExtra(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,cc):GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			--Cannot Special Summon monsters with the same name
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			--Cannot activate monster effects of cards with the same name
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,0)
			e2:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsCode(e:GetLabel()) end)
			e2:SetLabel(tc:GetCode())
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
	end
	elseif op==2 then
		--Fusion Summon 1 DARK Machine Fusion Monster
		local fusparams={handler=c,fusfilter=s.ffilter,matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
		Fusion.SummonEffOP(fusparams)(e,tp,eg,ep,ev,re,r,rp)
	end
end