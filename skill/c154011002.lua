--Shadow Game (Skill)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Shadow Games begin
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local gyc=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
	local gyo=Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)
	local damc=gyc*100
	local damo=gyo*100
	if gyc>4 and Duel.GetLP(tp)>1000 then
		Duel.SetLP(tp,Duel.GetLP(tp)-400)
	elseif gyc<=4 and Duel.GetLP(1-tp)>1000 then  
		Duel.SetLP(tp,Duel.GetLP(tp)-damc)
	end
	if gyo>4 and Duel.GetLP(1-tp)>1000 then
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-400)
	elseif gyo<=4 and Duel.GetLP(1-tp)>1000 then 
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-damo)
	end
end
