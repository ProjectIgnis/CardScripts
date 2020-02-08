HINT_SKILL = 200
HINT_SKILL_COVER = 201
HINT_SKILL_FLIP  = 202
-- HINT_SKILL_REMOVE = 203 (need to check with edo for name)

SKILL_COVER=300000000
--c: the card you want the cover (card)
--coverNum: the number of the cover, for ex, for the second cover, you pass 2 as a parameter (int)
function Auxiliary.GetCover(c,coverNum)
 return SKILL_COVER+(coverNum*1000000)+(c:GetOriginalRace())
end

--function that return if the player (tp) can activate the skill
--condition is no chain, it is your turn and it is the Main Phase
function Auxiliary.CanActivateSkill(tp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end

aux.DrawlessToken={}
aux.DrawlessToken[0]=nil
aux.DrawlessToken[1]=nil

function Auxiliary.RegisterDrawless(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.drawlessop)
	c:RegisterEffect(e1)
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

function Auxiliary.drawlessop(e,tp,eg,ep,ev,re,r,rp)
	if aux.DrawlessToken[e:GetHandlerPlayer()]==nil then
		aux.DrawlessToken[e:GetHandlerPlayer()]=Duel.CreateToken(e:GetHandlerPlayer(),946)
		aux.DrawlessToken[e:GetHandlerPlayer()]:Type(0)
		Duel.SendtoDeck(aux.DrawlessToken[e:GetHandlerPlayer()],nil,0,REASON_RULE)
	end
	e:Reset()
end
function Auxiliary.drawlessreset(e,tp,eg,ep,ev,re,r,rp)
	for i=0,1 do
		if aux.DrawlessToken[i] then
			local wasinhand=aux.DrawlessToken[i]:IsLocation(LOCATION_HAND)
			if not wasinhand then
				Duel.DisableShuffleCheck(true)
			end
			Duel.SendtoDeck(aux.DrawlessToken[i],nil,-2,REASON_RULE)
			if wasinhand then
				Duel.ShuffleHand(i)
			end
		end
	end
	e:Reset()
end
--proc for Field skills
--c: the skill (card)
--coverNum: the cover corresponding to the back (int)
--drawless: if the skill make you draw 1 less card at the start of the duel (bool)
function Auxiliary.AddFieldSkillProcedure(c,coverNum,drawless)
	c:Cover(Auxiliary.GetCover(c,coverNum))
	--place in field zone
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
		aux.RegisterDrawless(c)
	end
end
function Auxiliary.fieldop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck(true)
	p=e:GetHandler():GetControler()
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
	if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
		Duel.Draw(p,1,REASON_RULE)
	end
	e:Reset()
end

-- proc for continuous Spell/Trap Skill
-- c: the card (card)
-- coverNum: the Number of the cover (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool)
-- flip: if the continuous card get flipped at the start of the duel (bool)
function Auxiliary.AddContinuousSkillProcedure(c,coverNum,drawless,flip)
	c:Cover(Auxiliary.GetCover(c,coverNum))
	--place in correct zone, then if required, flip the skill
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(Auxiliary.continuousOp(flip))
	c:RegisterEffect(e1)
	--cannot to deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(0xff)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	if drawless then
		aux.RegisterDrawless(c)
	end
end
function Auxiliary.continuousOp(flip)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.DisableShuffleCheck(true)
		p=e:GetHandlerPlayer()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true,(1 << 2))
		if flip then
			Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
		end
		if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
			Duel.Draw(p,1,REASON_RULE)
		end
		e:Reset()
	end
end

-- Proc for basic skill
-- c: the card (card)
-- coverNum: the Number of the cover (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool)
-- flip con: condition to activate the skill (function)
-- flipOp: operation related to the skill activation (function)
function Auxiliary.AddSkillProcedure(c,coverNum,drawless,skillcon,skillop,countlimit)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetSkillOp(coverNum,drawless,skillcon,skillop,countlimit,EVENT_FREE_CHAIN))
	c:RegisterEffect(e1)
	if drawless then
		aux.RegisterDrawless(c)
	end
end

-- Duel.Hint(HINT_SKILL_COVER,1,coverID|(BackEntryID<<32))
-- Duel.Hint(HINT_SKILL,1,FrontID)
function Auxiliary.SetSkillOp(coverNum,drawless,skillcon,skillop,countlimit,efftype)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if skillop~=nil then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(efftype)
			if type(countlimit)=="number" then
				e1:SetCountLimit(countlimit)
			end
			e1:SetCondition(skillcon)
			e1:SetOperation(skillop)
			Duel.RegisterEffect(e1,e:GetHandlerPlayer())
		end
		local coverid = Auxiliary.GetCover(c,coverNum)
		Duel.DisableShuffleCheck(true)
		Duel.SendtoDeck(c,tp,-2,REASON_RULE)
		--generate the skill in the "skill zone"
		Duel.Hint(HINT_SKILL_COVER,c:GetControler(),coverid|(coverid<<32))
		Duel.Hint(HINT_SKILL,c:GetControler(),c:GetCode())			
		--send to limbo then draw 1 if the skill was in the hand
		if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then 
			Duel.Draw(p,1,REASON_RULE)
		end
		e:Reset()
	end
end

-- Function for the skills that "trigger" at the start of the turn/Before the Draw
-- c: the card (card)
-- coverNum: the Number of the cover (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool)
-- flip con: condition to activate the skill (function)
-- flipOp: operation related to the skill activation (function)
function Auxiliary.AddPreDrawSkillProcedure(c,coverNum,drawless,skillcon,skillop,countlimit)
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetSkillOp(coverNum,drawless,skillcon,skillop,countlimit,EVENT_PREDRAW))
	c:RegisterEffect(e1)
	if drawless then
		aux.RegisterDrawless(c)
	end
end
