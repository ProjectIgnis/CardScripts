--ラスト・クエスチョン
--Final Question
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(function(e) return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and Duel.IsAbleToEnterBP() end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(id,0))
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
	local quest=Duel.AnnounceNumber(1-tp,0,1,2,3,4,5,6,7,8,9,10,11,12)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetLabel(quest)
	e1:SetOperation(s.op)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(0)
	e2:SetOperation(s.endop)
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
function s.cfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
	Duel.Hint(HINT_CARD,0,id)
	local quest=e:GetLabel()
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if ct==quest then
		local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
		Duel.Destroy(sg,REASON_EFFECT)
	else
		local sg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,e)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		Duel.Hint(HINT_CARD,0,id)
		local sg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,e)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end