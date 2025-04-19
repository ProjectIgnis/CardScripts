--Action Field Generator
local s,id=GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s,function()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.op)
		Duel.RegisterEffect(e1,0)
	end )
	aux.EnableExtraRules(c,s,s.ActionStart)
end
function s.filter(c)
	return c:IsType(TYPE_ACTION) and not c.af and not c:IsOriginalCode(id)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck()
	Duel.SendtoDeck(Duel.GetMatchingGroup(s.filter,tp,0xff,0xff,nil),nil,-2,REASON_RULE)
	e:Reset()
end
function s.ActionStart()
	Duel.LoadScript("c151000000.lua")
	ActionDuel.Start()
end