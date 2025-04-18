--アマゾネス拝謁の間
--Amazoness Hall
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Gain LP equal to a target's ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.lpcond)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AMAZONESS}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.pendfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and Duel.CheckPendulumZones(tp)
end
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_AMAZONESS) and c:IsFaceup() and (c:IsAbleToHand() or s.pendfilter(c,tp))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local tc=g:Select(tp,1,1,nil)
		aux.ToHandOrElse(tc,tp,function(tc) return s.pendfilter(tc,tp) end,
						function(tc) Duel.MoveToField(tc:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) end,
						aux.Stringid(id,3)
						)
	end
end
function s.amzfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_AMAZONESS) and c:IsOriginalType(TYPE_MONSTER)
end
function s.lpcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.amzfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.lpfilter(c,e,tp)
	return c:IsControler(1-tp) and c:IsFaceup() and c:GetAttack()>0 and c:IsCanBeEffectTarget(e)
		and c:IsLocation(LOCATION_MZONE)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.lpfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.lpfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=eg:FilterSelect(tp,s.lpfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local value=tc:GetAttack()
		if value==0 then return end
		Duel.Recover(tp,value,REASON_EFFECT)
	end
end