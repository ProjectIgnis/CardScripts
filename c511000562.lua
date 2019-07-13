--Deepsea Warrior (DM)
--Scripted by edo9300
Duel.LoadScript("c300.lua")
local s,id=GetID()
function s.initial_effect(c)
	--immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--battle target
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(51100567,4))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(0xff)
	e2:SetCost(s.cbcost)
	e2:SetCondition(s.cbcon)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_UMI}
s.dm=true
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_UMI)
end
function s.econ(e)
	return Duel.IsExistingMatchingCard(s.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(CARD_UMI)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
function s.cbcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	Duel.Release(g,REASON_COST)
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	return bt:GetControler()==c:GetControler() and c:IsDeckMaster()
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetAttacker()
	if Duel.NegateAttack() then
		Duel.Damage(1-tp,tg:GetAttack(),REASON_EFFECT)
	end
end
