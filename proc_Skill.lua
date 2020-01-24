HINT_SKILL = 200
HINT_SKILL_COVER = 201
HINT_SKILL_FLIP  = 202
-- HINT_SKILL_REMOVE = 203 (need to check with edo for name)
aux.DrawlessToken={}
aux.DrawlessToken[0]=nil
aux.DrawlessToken[1]=nil
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
	if drawless then
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_STARTUP)
		e1:SetCountLimit(1)
		e1:SetRange(0x5f)
		e1:SetOperation(Auxiliary.drawlessop)
		c:RegisterEffect(e1)
	end
	if not aux.DrawlessGlobal then
		aux.DrawlessGlobal=true
		local e1=Effect.GlobalEffect()
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCountLimit(1)
		e1:SetOperation(Auxiliary.drawlessreset)
		Duel.RegisterEffect(e1,0)
	end
end
function Auxiliary.fieldop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		Duel.DisableShuffleCheck(e:GetHandlerPlayer())
		p=e:GetHandler():GetControler()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
	end
	if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
		Duel.Draw(p,1,REASON_RULE)
	end
	e:SetLabel(1)
	e:Reset()
end
function Auxiliary.drawlessop(e,tp,eg,ep,ev,re,r,rp)
	if aux.DrawlessToken[e:GetHandlerPlayer()]==nil then
		aux.DrawlessToken[e:GetHandlerPlayer()]=Duel.CreateToken(e:GetHandlerPlayer(),1)
		Duel.SendtoDeck(aux.DrawlessToken[e:GetHandlerPlayer()],nil,0,REASON_RULE)
	end
	e:Reset()
end
function Auxiliary.drawlessreset(e,tp,eg,ep,ev,re,r,rp)
	if aux.DrawlessToken[0] then
		local wasinhand=aux.DrawlessToken[0]:IsLocation(LOCATION_HAND)
		if not wasinhand then
			Duel.DisableShuffleCheck(0)
		end
		Duel.SendtoDeck(aux.DrawlessToken[0],nil,-2,REASON_RULE)
		if wasinhand then
			Duel.ShuffleHand(0)
		end
	end
	if aux.DrawlessToken[1] then
		local wasinhand=aux.DrawlessToken[1]:IsLocation(LOCATION_HAND)
		if not wasinhand then
			Duel.DisableShuffleCheck(1)
		end
		Duel.SendtoDeck(aux.DrawlessToken[1],nil,-2,REASON_RULE)
		if wasinhand then
			Duel.ShuffleHand(1)
		end
	end
	e:Reset()
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
		local c=e:GetHandler()
		if e:GetLabel()>0 then
			--generate the skill in the "skill zone"
			Duel.Hint(HINT_SKILL_COVER,c:GetControler(),coverid|(coverid<<32))
			Duel.Hint(HINT_SKILL,c:GetControler(),c:GetCode())			
			--send to limbo then draw 1 if the skill was in the hand
			Duel.SendtoDeck(c,tp,-2,REASON_RULE)
			if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
				Duel.Draw(p,1,REASON_RULE)
			end
		end
		e:SetLabel(0)
end
