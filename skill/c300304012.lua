--Middle Age Mechs (Skill Card)
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPreDrawSkillProcedure(c,2,false,s.flipcon,s.flipop,1)
end
s.listed_series={SET_ANCIENT_GEAR}
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnCount(tp)==1 and Duel.IsTurnPlayer(tp)
end
function s.flipop(e,tp,ep,eg,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,0x4)
	Duel.Hint(HINT_SKILL_REMOVE,tp,c:GetOriginalCode())
	--Counter Permit
	c:EnableCounterPermit(0xb)
	--"Ancient Gear" monsters gain 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ANCIENT_GEAR))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Place 1 counter on this card each time a monster is Normal Summoned/Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.addc)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_MSET)
	c:RegisterEffect(e3)
	--Tribute Subsitution for Ancient Gear monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(id)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		--summon proc
		local ge1=Effect.CreateEffect(c)
		ge1:SetDescription(aux.Stringid(id,0))
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_SUMMON_PROC)
		ge1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
		ge1:SetCondition(s.sumcon)
		ge1:SetTarget(aux.FieldSummonProcTg(aux.TargetBoolFunction(Card.IsSetCard,SET_ANCIENT_GEAR),s.sumtg))
		ge1:SetOperation(s.sumop)
		ge1:SetValue(SUMMON_TYPE_TRIBUTE)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xb,1)
end
function s.castlefilter(c,tp,mi)
	return c:IsHasEffect(id) and c:GetCounter(0xb)>=mi and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsReleasable()
end
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local mi,ma=c:GetTributeRequirement()
	if mi<minc then mi=minc end
	if ma<mi then return false end
	return ma>0 and Duel.IsExistingMatchingCard(s.castlefilter,c:GetControler(),LOCATION_SZONE,0,1,nil,c:GetControler(),mi)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	tp=c:GetControler()
	local mi,ma=c:GetTributeRequirement()
	local sg=Duel.SelectMatchingCard(tp,s.castlefilter,tp,LOCATION_SZONE,0,1,1,true,nil,tp,mi)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Release(sg,REASON_COST)
	sg:DeleteGroup()
end