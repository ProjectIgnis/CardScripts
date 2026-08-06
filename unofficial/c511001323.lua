--忍法・天空大凧
--Great Kite of Ninja
local s,id=GetID()
function s.initial_effect(c)
	--Equip this card only to "Ninja Master Shogun"
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,511001322))
	--Negate any Spells or Traps that target the equipped monster.
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_DISABLE)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1a:SetTarget(s.distg)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_CHAIN_SOLVING)
	e1b:SetRange(LOCATION_SZONE)
	e1b:SetOperation(s.disop)
	c:RegisterEffect(e1b)
	--Your opponent's monsters cannot select the equipped monster as an attack target, but it does not prevent your opponent from attacking you directly.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--You can Tribute 1 monster, except the equipped monster; the equipped monster can attack directly this turn.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37433748,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(function() Duel.IsAbleToEnterBP() end)
	e3:SetCost(s.diratkcost)
	e3:SetOperation(s.diratkop)
	c:RegisterEffect(e3)
end
s.listed_names={511001322} --"Ninja Master Shogun"
function s.eqfilter(c,eq,eqc)
	return eq==c and c:GetEquipGroup():IsContains(eqc)
end
function s.distg(e,c)
	local ec=e:GetHandler()
	if c==ec or c:GetCardTargetCount()==0 then return false end
	local eqc=ec:GetEquipTarget()
	return eqc and (c:IsHasCardTarget(eqc) or c:GetCardTarget():IsExists(s.eqfilter,1,nil,eqc,c)) and c:IsSpellTrap()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not re:IsSpellTrapEffect() or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(ec) then return end
	Duel.NegateEffect(ev)
end
function s.diratkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,ec) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,ec)
	Duel.Release(g,REASON_COST)
end
function s.diratkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
