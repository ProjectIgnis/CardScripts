--Superheavy Samurai Otasu-Ke
local s,id=GetID()
function s.initial_effect(c)
	--Damage to 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.defcon)
	e1:SetCost(s.defcost)
	e1:SetTarget(s.deftg)
	e1:SetOperation(s.defop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a:IsDefensePos() or (d and d:IsDefensePos()))
		and (Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0)
		and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.deffilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deffilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local tc = nil
	if a:IsDefensePos() then
		if d and d:IsDefensePos() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			tc = Group.FromCards(a,d):Select(tp,1,1,nil)
		end
		tc = a
	elseif d and d:IsDefensePos() then
		tc = d
	end
	if not tc or not Duel.IsExistingMatchingCard(s.deffilter,tp,LOCATION_MZONE,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local c = Duel.SelectMatchingCard(tp,s.deffilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(c:GetDefense())
	tc:RegisterEffect(e1)
end
