--見えざる幽獄
--Hecahands Tartarus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Hecahands Tartarus" once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--If you use a face-up monster(s) you control owned by your opponent, you can treat it as a "Hecahands" monster
	aux.GlobalCheck(s,function()
		local e0a=Effect.CreateEffect(c)
		e0a:SetType(EFFECT_TYPE_FIELD)
		e0a:SetCode(EFFECT_ADD_SETCODE)
		e0a:SetTargetRange(LOCATION_MZONE,0)
		e0a:SetTarget(function(e,c) local tp=e:GetHandlerPlayer() return c:IsFaceup() and c:IsControler(tp) and c:IsOwner(1-tp) end)
		e0a:SetOperation(s.chngcon)
		e0a:SetValue(SET_HECAHANDS)
		Duel.RegisterEffect(e0a,0)
		local e0b=e0a:Clone()
		Duel.RegisterEffect(e0b,1)
	end)
end
s.listed_series={SET_HECAHANDS}
function s.chngcon(scard,sumtype,tp)
	return Fusion.SummonEffect and Fusion.SummonEffect:GetHandler():IsCode(id) and ((sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local fusion_params={handler=e:GetHandler(),fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_HECAHANDS),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_HECAHANDS),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	local cost_skip=e:GetLabel()~=-100
	local fusion_params={handler=e:GetHandler(),fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_HECAHANDS),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_HECAHANDS),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectTarget(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_FUSION_SUMMON)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Return 1 Spell/Trap your opponent controls to the hand
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	elseif op==2 then
		--Fusion Summon 1 "Hecahands" Fusion Monster from your Extra Deck, by banishing its materials from your field and/or GY
		local fusion_params={handler=e:GetHandler(),fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_HECAHANDS),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),extrafil=s.fextra,extraop=Fusion.BanishMaterial,extratg=s.extratg}
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end