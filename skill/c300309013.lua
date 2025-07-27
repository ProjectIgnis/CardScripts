--Malevolence of the Millenium Ring
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
	--Choose 1 of these Skills to activate (Send 1 Fiend to GY,Discard 1 Fiend to draw 1 card)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(0x5f)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	Duel.RegisterEffect(e2,tp)
end
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
function s.discardfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and not Duel.HasFlagEffect(tp,id)
	local b2=Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) and not Duel.HasFlagEffect(tp,id+100)
	--condition
	if chk==0 then return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FIEND),tp,LOCATION_MZONE,0,1,nil) and (b1 or b2) end
	--Choose Skill(Send 1 Fiend monster to GY, Discard 1 Fiend to draw 1 card)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Send 1 Fiend monster from your Deck to the GY, then lose LP equal to its original Level x 200
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
			local lp=tg:GetFirst():GetOriginalLevel()*200
			Duel.BreakEffect()
			Duel.SetLP(tp,Duel.GetLP(tp)-lp)
		end
	elseif op==2 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Discard 1 Fiend monster to draw 1 card, lose LP equal to its original Level x 200, then draw 1 card
		if Duel.DiscardHand(tp,s.discardfilter,1,1,REASON_COST|REASON_DISCARD,nil)>0 then
			local lp=Duel.GetOperatedGroup():GetFirst():GetOriginalLevel()*200
			Duel.SetLP(tp,Duel.GetLP(tp)-lp)
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end	
	end
end