--聖天樹の輝常緑
--Sunavalon Glorious Growth
--Fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(99427357,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_RECOVER)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Negate Attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99427357,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.sdescon)
	e4:SetOperation(s.sdesop)
	c:RegisterEffect(e4)
end
s.listed_series={0x574,0x575}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009676,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.linkfilter(c)
	return c:IsSpecialSummonable(SUMMON_TYPE_LINK) and c:IsSetCard(0x574)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,511009676,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,511009676)
	-- Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- Duel.SpecialSummonComplete()
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)~=0 
		and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil) then
		local tc=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		Duel.SpecialSummonRule(tp,tc,SUMMON_TYPE_LINK)
		Duel.BreakEffect()
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
--------------------------------------
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end
--------------------------------------
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetAttacker()
	if Duel.NegateAttack() and tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetValue(s.atlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e3)
		Duel.ChainAttack()
	end
end
function s.atlimit(e,c)
	return c:GetControler(e:GetOwnerPlayer()) and (not c:IsSetCard(0x575) or c:IsFacedown())
end
--------------------------------------
function s.sfilter(c,p)
	return c:GetPreviousControler()==p and c:IsPreviousSetCard(0x574)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sdescon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil,tp)
end
function s.sdesop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
