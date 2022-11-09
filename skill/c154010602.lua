--Grandpa's Cards
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
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_STARTUP)
		ge1:SetRange(0x5f)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={44519536,7902349,33396948,70903634,8124921}
function s.filter(c)
	return c:IsCode(44519536) or c:IsCode(7902349) or c:IsCode(33396948) or c:IsCode(70903634) or c:IsCode(8124921)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) then
		e:GetHandler():RegisterFlagEffect(id,0,0,0)
	end
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 or e:GetHandler():GetFlagEffect(id)>0 then return false end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Grandpas Cards
	local g1=Duel.CreateToken(tp,44519536)
	local g2=Duel.CreateToken(tp,7902349)
	local g3=Duel.CreateToken(tp,33396948)
	local g4=Duel.CreateToken(tp,70903634)
	local g5=Duel.CreateToken(tp,8124921)
	local sg=Group.FromCards(g1,g2,g3,g4,g5)
	if #sg>0 then 
		Duel.SendtoDeck(sg,tp,2,REASON_EFFECT)
	end
end