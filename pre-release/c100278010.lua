--ドクターＤ
--Doctor D
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
	--Change ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0xc008}
function s.costfilter(c,e,tp,ft)
	return c:IsSetCard(0xc008) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,c,e,tp,ft)
end
function s.filter(c,e,tp,ft)
	return (c:IsSetCard(0xc008) and c:IsMonster()) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp,ft)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,0))
	end
end
function s.atkfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc008) and c:IsMonster()
		and Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_MZONE,0,1,c,c:GetAttack())
end
function s.atkfilter2(c,atk)
	return c:IsFaceup() and c:IsSetCard(0xc008) and c:IsMonster() and not c:IsAttack(atk)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g1=Duel.SelectTarget(tp,s.atkfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,s.atkfilter2,tp,LOCATION_MZONE,0,1,1,g1,g1:GetFirst():GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if not #g==2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tg=g:Select(tp,1,1,nil)
	Duel.HintSelection(tg)
	local hc=tg:GetFirst()
	local tc=(g-hc):GetFirst()
	if hc and tc then
		local atk=tc:GetAttack()
		--Change ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e1) 
	end
end