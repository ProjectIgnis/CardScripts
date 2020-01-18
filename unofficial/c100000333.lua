--Ｆａｉｒｙ Ｔａｌｅ最終章 忘却の妖月
--Fairy Tale Final Chapter: Moon of Oblivion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)	
	--unnegatable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.accon)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	c:RegisterEffect(e4)
end
s.listed_names={100000330}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (r&REASON_RULE)~=0 and Duel.GetTurnCount()==1 then
		--obsolete
		Duel.RegisterFlagEffect(tp,62765383,0,0,1)
		Duel.RegisterFlagEffect(1-tp,62765383,0,0,1)
	end
end
function s.filter(c,tp)
	return c:IsCode(100000330) and c:GetActivateEffect():IsActivatable(tp)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0x13,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
function s.pofilter1(c,e,tp)
	return c:GetPosition()==POS_FACEUP_ATTACK and c:GetPreviousPosition()>0x3
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return eg:IsContains(chkc) and s.pofilter1(chkc) end
	if chk==0 then return eg:IsExists(s.pofilter1,1,nil) end
	return true
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.pofilter1,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	 tc=g:GetNext()
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFlagEffect(tp,100000330)==0
end
function s.posfilter(c,e)
	return bit.band(c:GetPreviousPosition(),POS_DEFENSE)~=0 and c:IsPosition(POS_FACEUP_ATTACK) 
		and (not e or c:IsRelateToEffect(e))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.posfilter,1,nil,e) and rp==tp end
	Duel.SetTargetCard(eg)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.posfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
function s.filter(c,tp)
	return c:IsCode(100000330) and c:GetActivateEffect():IsActivatable(tp)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end

