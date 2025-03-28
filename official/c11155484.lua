--宝玉の奇跡
--Crystal Miracle
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 "Crystal Beast" card and negate activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Place 1 "Crystal Beast" in your Spell/Trap Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.plcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CRYSTAL_BEAST}
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_CRYSTAL_BEAST),tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local dg=nil
	local ct=0
	if re:GetHandler():IsRelateToEffect(re) then
		dg=eg
		ct=1
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1+ct,tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_CRYSTAL_BEAST),tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0
		and Duel.NegateActivation(ev)
		and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.plconfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsControler(tp) and c:GetSequence()<5
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.plconfilter,1,nil,tp)
end
function s.plfilter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsMonster() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Treat as Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end