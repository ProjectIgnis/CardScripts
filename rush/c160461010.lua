--惑精のプルアモネ
--Pluamone the Planetairy
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card from your hand face-up to your field by revealing 1 "Princess Cosmos the Trickster" or 1 "Princess Cosmos' Jest" in your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Fusion Summon a Galaxy Type monster with 1900 DEF by sending 2 monsters from your hand and/or field to the Graveyard as material
	local fusion_params={fusfilter=aux.FilterBoolFunction(s.fusfilter),exactcount=2}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
	--Register when a card is destroyed
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={160216046,160017058} --"Princess Cosmos the Trickster", "Princess Cosmos' Jest"
function s.spcfilter(c)
	return c:IsCode(160216046,160017058) and not c:IsPublic()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,e:GetHandler())
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_CONFIRM,nil,nil,true)
	if #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in eg:Iter() do
		if ec:IsPreviousLocation(LOCATION_ONFIELD) and ec:IsReason(REASON_EFFECT) then
			Duel.RegisterFlagEffect(ec:GetPreviousControler(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.fusfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsDefense(1900)
end