-- Prescience
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:Cover(id)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	
	--cannot to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(0xff)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
		if e:GetLabel()==0 then
			p=e:GetHandler():GetControler()
			Duel.Hint(HINT_SKILL_COVER,0,id)
			
			
			-- local e1=Effect.CreateEffect(e:GetHandler())
			-- e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			-- e1:SetCode(EVENT_FREE_CHAIN)
			-- e1:SetLabelObject(e:GetHandler())
			-- e1:SetCondition(s.flipcon)
			-- e1:SetOperation(s.flipop)
			-- Duel.RegisterEffect(e1,tp)
		end
	e:SetLabel(1)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local skillcard=e:GetLabelObject()
	
	if not skillcard:IsFacedown()  then return false end
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
	-- and (Duel.GetLP(skillcard:GetControler())*2)<=Duel.GetLP(1-skillcard:GetControler())
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local skillcard=e:GetLabelObject()
	if skillcard:IsFacedown() then Duel.ChangePosition(skillcard,POS_FACEUP_ATTACK) end
	Duel.Hint(HINT_CARD,0,id)
	-- prescience effect
	local g=Duel.GetDecktopGroup(1-tp,1)
	Duel.ConfirmCards(tp,g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(e:GetHandler():GetControler(),1)
	Debug.Message(g:GetFirst():GetCode())
	Debug.Message(g:GetFirst():GetFlagEffect(300000034)==0)
	if g:GetFirst():GetFlagEffect(300000034)==0 then
		local g=Duel.GetDecktopGroup(1-tp,1)
		Duel.ConfirmCards(tp,g)
		g:GetFirst():RegisterFlagEffect(300000034,RESET_EVENT+0x1fe0000,0,1)
	end
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local skillcard=e:GetLabelObject()
	local g=Duel.GetDecktopGroup(skillcard:GetControler(),1)
	
	if g:GetFirst():GetFlagEffect(id)==0 then
		local g=Duel.GetDecktopGroup(tp,1)
		Duel.ConfirmCards(tp,g)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
	end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local skillcard=e:GetLabelObject()
	local g=Duel.GetDecktopGroup(skillcard:GetControler(),1)
	
	if g:GetFirst():GetFlagEffect(id)==0 then
		local g=Duel.GetDecktopGroup(1-tp,1)
		Duel.ConfirmCards(tp,g)
		g:GetFirst():RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1)
	end
end