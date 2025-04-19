--ドロー・ロック
--Lock Draw
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)==0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(1-tp,id,0,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id,1))
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.cannotDrawCondition)
	Duel.RegisterEffect(e1,1-tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetValue(0)
	Duel.RegisterEffect(e2,1-tp)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.canDiscardCondition)
	e3:SetOperation(s.discardOp)
	Duel.RegisterEffect(e3,1-tp)
	local e4=Effect.GlobalEffect()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.canDiscardCondition)
	e4:SetOperation(function(e,tp)
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			s.discardOp(e,tp)
		end
	end)
	Duel.RegisterEffect(e4,1-tp)
end
function s.cannotDrawCondition(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end
function s.acfilter(c)
	return c:IsType(TYPE_ACTION) and not c:IsType(TYPE_FIELD) and c:IsAbleToGrave()
end
function s.canDiscardCondition(e,tp)
	return Duel.GetFlagEffect(tp,id)>0 and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.discardOp(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoGrave(g,REASON_EFFECT)
		Duel.ResetFlagEffect(tp,id)
	end
end