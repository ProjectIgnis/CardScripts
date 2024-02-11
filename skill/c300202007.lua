--Aroma Strategy
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(LOCATION_ALL)
	e1:SetCountLimit(1)
	e1:SetOperation(s.startop)
	c:RegisterEffect(e1)
end
function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(function() return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 end)
	e1:SetOperation(s.flipop)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Aroma effect on adjust
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.adjrevop)
	Duel.RegisterEffect(e1,tp)
	--Aroma effect manually
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(function(e,tp) return Duel.GetDecktopGroup(tp,1):GetFirst() end)
	e2:SetOperation(s.manualrevop)
	Duel.RegisterEffect(e2,tp)
end
function s.adjrevop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not tc or tc:HasFlagEffect(id) then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectCardsFromCodes(tp,0,1,true,false,tc:GetCode())
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.manualrevop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	Duel.SelectCardsFromCodes(tp,0,1,true,false,tc:GetCode())
end
