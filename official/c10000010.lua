--ラーの翼神竜
--The Winged Dragon of Ra
local s,id=GetID()
function s.initial_effect(c)
	--Normal Summon with 3 Tributes
	aux.AddNormalSummonProcedure(c,true,false,3,3)
	aux.AddNormalSetProcedure(c)
	--Cannot be Special Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.spval)
	c:RegisterEffect(e0)
	--This card's Normal Summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	c:RegisterEffect(e1)
	--Other cards and effects cannot be activated when Normal Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(function(e) Duel.SetChainLimitTillChainEnd(s.genchainlm(e:GetHandler())) end)
	c:RegisterEffect(e2)
	--One Turn Kill
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCost(s.atkcost)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Destroy 1 monster on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(Cost.PayLP(1000))
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.spval(e,se,sp,st)
	return st==SUMMON_TYPE_SPECIAL+SUMMON_WITH_MONSTER_REBORN and Duel.IsPlayerAffectedByEffect(sp,41044418) and e:GetHandler():IsControler(sp)
end
function s.genchainlm(c)
	return	function(e,rp,tp)
			return e:GetHandler()==c
		end
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp_cost=Duel.GetLP(tp)-100
	if chk==0 then return lp_cost>0 and Duel.CheckLPCost(tp,lp_cost) end
	e:SetLabel(lp_cost)
	Duel.PayLPCost(tp,lp_cost)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Increase ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
