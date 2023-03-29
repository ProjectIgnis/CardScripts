--ＶＶ―マスターフェイズ
--Vaylantz Wave - Master Phase
--scripted by pyrQ
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
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VAYLANTZ}
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.atkfilter(c)
	return c:IsSetCard(SET_VAYLANTZ) and c:IsLevelAbove(5) and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MMZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) end
	local c=e:GetHandler()
	local not_dmg_step=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	local b1=Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) and (not_dmg_step or not Duel.IsDamageCalculated())
	local b2=c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) and not_dmg_step
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MMZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local prop=EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP
	if op==1 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(prop)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(prop+EFFECT_FLAG_CARD_TARGET)
		Duel.SendtoGrave(c,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MMZONE,1,1,nil,tp):GetFirst()
		local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,tc:GetSequence())
		if dc then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,dc,1,PLAYER_NONE,0)
		end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		--Your Level 5 or higher "Vaylantz" monsters gain 1200 ATK
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		for tc in g:Iter() do
			--Increase ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1200)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Place the target face-up in the Spell & Trap Zone as a Continuous Spell
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
		local seq=tc:GetSequence()
		local dc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,seq)
		if dc then
			Duel.Destroy(dc,REASON_RULE)
		end
		if Duel.CheckLocation(1-tp,LOCATION_SZONE,seq)
			and Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,1<<seq) then
			--Treat it as a Continuous Spell
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end
end