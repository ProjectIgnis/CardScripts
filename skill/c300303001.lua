--Fury of Thunder
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={10000020}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 and Duel.GetFlagEffect(ep,id)==0
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=(Duel.GetFlagEffect(ep,id)==0 and s.drtg(e,tp,eg,ep,ev,re,r,rp,0)) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4
	local b2=Duel.GetFlagEffect(ep,id+1)==0
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
--effect 1
function s.filter(c)
	return c:IsCode(10000020) and c:IsFaceup()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=4-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,ct,tp,0)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local ct=4-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,ct) then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.tdcon)
	e2:SetOperation(s.tdop)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
end
function s.tdfilter(c,tp)
	return c:IsCode(10000020) and c:IsAbleToDeck() and c:IsControler(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdfilter,1,nil,tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:Filter(s.tdfilter,nil,tp)
	if ec and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SendtoDeck(ec,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
