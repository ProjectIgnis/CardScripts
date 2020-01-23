HINT_SKILL = 200
HINT_SKILL_COVER = 201
HINT_SKILL_FLIP  = 202
-- HINT_SKILL_REMOVE = 203 (need to check with edo for name)
function Auxiliary.AddFieldSkillProcedure(c,coverid,drawless)
	c:Cover(coverid)
	--place on field
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(Auxiliary.fieldop)
	c:RegisterEffect(e1)
	--cannot to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(0xff)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--If the card have an "You draw 1 less card at the beginning of the Duel" condition
	-- if drawless==true then
	-- local e1=Effect.CreateEffect(c)	
	-- e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	-- e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- e1:SetCode(EVENT_STARTUP)
	-- e1:SetCountLimit(1)
	-- e1:SetRange(0x5f)
	-- e1:SetOperation(Auxiliary.drawlessop)
	-- c:RegisterEffect(e1)
	-- end
	
	
end
function Auxiliary.fieldop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		p=e:GetHandler():GetControler()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
	end
		if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
			Duel.Draw(p,1,REASON_RULE)
		end
	e:SetLabel(1)
end
function Auxiliary.drawlessop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local dg=sg:RandomSelect(tp,1)
	if #dg==0 then return end
	Duel.SendtoDeck(dg,nil,2,REASON_RULE)
end


-- c: the card (card)
-- coverid: the ID of the cover (in the cover folder of pics folder) (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool)
-- flip: if the continuous card get flipped at the start of the duel (bool)
function Auxiliary.AddContinuousSkillProcedure(c,coverid,drawless,flip)
	c:Cover(coverid)
	--activate
	if flip==true then
		local e1=Effect.CreateEffect(c)	
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetCountLimit(1)
		e1:SetRange(0x5f)
		e1:SetLabel(0)
		e1:SetOperation(Auxiliary.continuousFlipOp)
		c:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(c)	
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetCountLimit(1)
		e1:SetRange(0x5f)
		e1:SetLabel(0)
		e1:SetOperation(Auxiliary.continuousOp)
		c:RegisterEffect(e1)
	end
	--cannot to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(0xff)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function Auxiliary.continuousFlipOp(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		p=e:GetHandler():GetControler()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,(1 << 2))
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
	end
		if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
			Duel.Draw(p,1,REASON_RULE)
		end
	e:SetLabel(1)
end


-- c: the card (card)
-- coverid: the ID of the cover (in the cover folder of pics folder) (int)
-- dummyEntryID: ID of the entry displayed when hovering and the card is set
-- drawless: if the player draw 1 less card at the start of the duel (bool)
-- flip con: condition to activate the skill
-- flipOp: operation related to the skill activation
function Auxiliary.AddSkillProcedure(c,coverid,drawless,skillcon,skillop)
	--activate
	
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(coverid)
	e1:SetOperation(Auxiliary.SetSkillOp)
	c:RegisterEffect(e1)
	
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(skillcon)
	e1:SetOperation(skillop)
	Duel.RegisterEffect(e1,tp)
end

-- Duel.Hint(HINT_SKILL_COVER,1,coverID|(BackEntryID<<32))
-- Duel.Hint(HINT_SKILL,1,FrontID)
function Auxiliary.SetSkillOp(e,tp,eg,ep,ev,re,r,rp)
		local coverid = e:GetLabel()
	
		if e:GetLabel()>0 then
			
			Duel.Hint(HINT_SKILL_COVER,e:GetHandler():GetControler(),coverid|(coverid<<32))
			Duel.Hint(HINT_SKILL,e:GetHandler():GetControler(),e:GetHandler():GetCode())			
			
		end
	e:SetLabel(0)
end