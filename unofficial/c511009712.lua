--プロパティ・スプレイ
--Property Spray
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(s.reccost)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.reccost(e,tp,eg,ep,ev,re,r,rp,0) and s.rectg(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:SetCategory(CATEGORY_RECOVER)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		s.reccost(e,tp,eg,ep,ev,re,r,rp,1)
		s.rectg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.recop)
	else
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.costfilter(c,p)
	local att=c:GetAttribute()
	return c:GetAttack()>0 and att>0
		 and Duel.IsExistingMatchingCard(aux.NOT(aux.FilterEqualFunction(Card.GetAttribute)),p,0,LOCATION_MZONE,1,c,att)
end
function s.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.Release(g,REASON_COST)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	local atk=tc:GetPreviousAttackOnField()
	e:SetLabel(tc:GetPreviousAttributeOnField())
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local att=e:GetLabel()
	if Duel.Recover(p,d,REASON_EFFECT)>0 and att>0 then
		local g=Duel.GetMatchingGroup(aux.NOT(aux.FilterEqualFunction(Card.GetAttribute)),tp,0,LOCATION_MZONE,nil,att)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(att)
			tc:RegisterEffect(e1)
		end
	end
end