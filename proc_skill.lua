HINT_SKILL = 200
HINT_SKILL_COVER = 201
HINT_SKILL_FLIP  = 202
HINT_SKILL_REMOVE = 203

SKILL_COVER =   300000000
VRAINS_SKILL_COVER  =   300000001

EFFECT_NEGATE_SKILL =   152000015
--c: the card you want the cover (card)
--coverNum: the number of the cover, for ex, for the second cover, you pass 2 as a parameter (int)
function Auxiliary.GetCover(c,coverNum)
 return SKILL_COVER+(coverNum*1000000)+(c:GetOriginalRace())
end

--function that return if the player (tp) can activate the skill
--condition is no chain, it is your turn and it is the Main Phase
function Auxiliary.CanActivateSkill(tp)
	return Duel.GetCurrentChain()==0 and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
end
--If the card have an "You draw 1 less card at the beginning of the Duel" condition
Auxiliary.Drawless={}
function Auxiliary.AddDrawless(c,drawless)
	local typ=type(drawless)
	if typ=="number" or (typ=="boolean" and drawless) then
		Auxiliary.Drawless[c]=typ=="number" and drawless or 1
	end
end
function Auxiliary.drawlessop(e)
	e:Reset()
	local t={}
	t[0]=0
	t[1]=0
	for c,val in pairs(aux.Drawless) do
		t[c:GetControler()]=t[c:GetControler()]+val
	end
	for p=0,1 do
		if t[p]~=0 then
			Debug.SetPlayerInfo(p,Duel.GetLP(p),Duel.GetStartingHand(p)-t[p],Duel.GetDrawCount(p))
		end
	end
end
local drawlesseff=Effect.GlobalEffect()
drawlesseff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
drawlesseff:SetCode(EVENT_STARTUP)
drawlesseff:SetOperation(aux.drawlessop)
Duel.RegisterEffect(drawlesseff,0)

-- proc for Field skills
-- c: the skill (card)
-- coverNum: the cover corresponding to the back (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool) or the amount of cards to draw less (int)
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
	Auxiliary.AddDrawless(c,drawless)
end
function Auxiliary.fieldop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DisableShuffleCheck(true)
	p=e:GetHandler():GetControler()
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_FZONE,POS_FACEDOWN,true)
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
	if e:GetHandler():IsPreviousLocation(LOCATION_HAND) then
		Duel.Draw(p,1,REASON_RULE)
	end
	e:Reset()
end

-- proc for continuous Spell/Trap Skill
-- c: the card (card)
-- coverNum: the Number of the cover (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool) or the amount of cards to draw less (int)
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
	Auxiliary.AddDrawless(c,drawless)
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
-- drawless: if the player draw 1 less card at the start of the duel (bool) or the amount of cards to draw less (int)
-- flip con: condition to activate the skill (function)
-- flipOp: operation related to the skill activation (function)
function Auxiliary.AddSkillProcedure(c,coverNum,drawless,skillcon,skillop,countlimit)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetSkillOp(coverNum,skillcon,skillop,countlimit,EVENT_FREE_CHAIN))
	c:RegisterEffect(e1)
	Auxiliary.AddDrawless(c,drawless)
end

-- Duel.Hint(HINT_SKILL_COVER,1,coverID|(BackEntryID<<32))
-- Duel.Hint(HINT_SKILL,1,FrontID)
function Auxiliary.SetSkillOp(coverNum,skillcon,skillop,countlimit,efftype)
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
		if c:IsPreviousLocation(LOCATION_HAND) then
			Duel.Draw(c:GetControler(),1,REASON_RULE)
		end
		e:Reset()
	end
end

-- Function for the skills that "trigger" at the start of the turn/Before the Draw
-- c: the card (card)
-- coverNum: the Number of the cover (int)
-- drawless: if the player draw 1 less card at the start of the duel (bool) or the amount of cards to draw less (int)
-- flip con: condition to activate the skill (function)
-- flipOp: operation related to the skill activation (function)
function Auxiliary.AddPreDrawSkillProcedure(c,coverNum,drawless,skillcon,skillop,countlimit)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetSkillOp(coverNum,skillcon,skillop,countlimit,EVENT_PREDRAW))
	c:RegisterEffect(e1)
	Auxiliary.AddDrawless(c,drawless)
end

--Proc for Vrains Skills
--flip con: condition to activate the skill (function)
--flipOp: operation related to the skill activation (function)
--efftype: Event to trigger the Skill, default to EVENT_FREE_CHAIN. Additionally accept EFFECT_NEGATE_SKILL for Anti Skill (int)
function Auxiliary.AddVrainsSkillProcedure(c,skillcon,skillop,efftype)
	efftype=efftype or EVENT_FREE_CHAIN
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(Auxiliary.SetVrainsSkillOp(skillcon,skillop,efftype))
	c:RegisterEffect(e1)
end
function Auxiliary.SetVrainsSkillOp(skillcon,skillop,efftype)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if skillop~=nil then
			local e1=Effect.CreateEffect(c)
			if efftype~=EFFECT_NEGATE_SKILL then
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			else
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(1,0)
			end
			e1:SetCode(efftype)
			e1:SetCondition(skillcon)
			e1:SetOperation(skillop)
			Duel.RegisterEffect(e1,e:GetHandlerPlayer())
			if efftype==EVENT_FREE_CHAIN then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_END)
				e1:SetCondition(skillcon)
				e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) if Duel.SelectYesNo(tp,aux.Stringid(c:GetOriginalCode(),0)) then skillop(e,tp,eg,ep,ev,re,r,rp) end end)
				Duel.RegisterEffect(e1,e:GetHandlerPlayer())
			end
		end
		Duel.DisableShuffleCheck(true)
		Duel.SendtoDeck(c,tp,-2,REASON_RULE)
		Duel.Hint(HINT_SKILL_COVER,c:GetControler(),VRAINS_SKILL_COVER)
		Duel.Hint(HINT_SKILL,c:GetControler(),c:GetCode())
		if c:IsPreviousLocation(LOCATION_HAND) then
			Duel.Draw(c:GetControler(),1,REASON_RULE)
		end
		e:Reset()
	end
end

--Function to check whether the Skill would be negated by Anti Skill
function Auxiliary.CheckSkillNegation(e,tp)
	if Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NEGATE_SKILL) then
		local eff=Duel.GetPlayerEffect(1-tp,EFFECT_NEGATE_SKILL)
		if eff:GetCondition()(eff,1-tp,e) then
			local chk=eff:GetOperation()(eff,1-tp,e)
			if chk then Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(EFFECT_NEGATE_SKILL,1)) end
			return chk
		else return false end
	else return false end
end
