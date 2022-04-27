-- ジョイント・チェア 
-- Joint Chair

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetAttack()==0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.cfilter),tp,LOCATION_MZONE,0,3,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,2,nil)
	if #g2>0 then
		Duel.HintSelection(g2)
		for tc in g2:Iter() do
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
			local ge0=Effect.CreateEffect(e:GetHandler())
			ge0:SetType(EFFECT_TYPE_SINGLE)
			ge0:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			ge0:SetValue(s.vala)
			local ge1=Effect.CreateEffect(e:GetHandler())
			ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
			ge1:SetProperty(EFFECT_FLAG_OATH)
			ge1:SetTargetRange(0,LOCATION_MZONE)
			ge1:SetTarget(s.eftg)
			ge1:SetCondition(s.con)
			ge1:SetLabelObject(ge0)
			ge1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(ge1,tp)
			--cannot attack directly with other cards
			local ge2=Effect.CreateEffect(e:GetHandler())
			ge2:SetType(EFFECT_TYPE_FIELD)
			ge2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			ge2:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
			ge2:SetTargetRange(0,LOCATION_MZONE)
			ge2:SetTarget(s.eftg)
			ge2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(ge2,tp)
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.effilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.effilter(c)
	return c:IsPosition(POS_DEFENSE)
end
function s.eftg(e,c)
	return c:IsFaceup()
end
function s.vala(e,c)
	return not c:IsDefensePos()
end