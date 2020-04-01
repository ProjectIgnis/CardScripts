--ギミック・パペット－ボム・エッグ
local s,id=GetID()
function s.initial_effect(c)
	--effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={0x83}
function s.cfilter(c)
	return c:IsSetCard(0x83) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
	local opt=0
	if e:GetHandler():GetLevel()==8 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	end
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	else
		e:SetCategory(CATEGORY_LVCHANGE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e:GetHandler():RegisterEffect(e1)
	end
end
