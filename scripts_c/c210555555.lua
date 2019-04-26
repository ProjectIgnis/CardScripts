--[[
	your hand. If this card is Special Summoned, you cannot Normal or Special Summon monsters for the rest of this turn except LIGHT monsters.
	You can target 1 Rank 5 monster you control; move it to another zone.
	This card's name becomes "Cyber Dragon", while it is on the field or in the GY.
	An Xyz Monster that was Summoned using this card on the field as Xyz material gains this effect:
	(*)Once while face-up on the field (Quick Effect): Target one Xyz monster on the field; move it to another of the controller's unoccupied Main or Extra Deck Monster Zones.
	You can only use each effect of "Cyber Dragon Vier" once per turn
--]]
function c210555555.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,210555555)
	e1:SetCondition(c210555555.spcon)
	c:RegisterEffect(e1) 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c210555555.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63394872,0))
	e3:SetCountLimit(1,210555555+100)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c210555555.target)
	e3:SetOperation(c210555555.operation)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetValue(70095154)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetCondition(c210555555.efcon)
	e5:SetOperation(c210555555.efop)
	c:RegisterEffect(e5)
	--with a bit of magic it became a cydra 
  	local e6=Effect.CreateEffect(c)
  	e6:SetType(EFFECT_TYPE_SINGLE)
  	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 	e6:SetCode(EFFECT_CHANGE_CODE)
  	e6:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
  	e6:SetValue(70095154)
  	c:RegisterEffect(e6)
end 
--sp effects 
function c210555555.spfilter(c)
	return c:GetLevel()==5 or c:GetRank()==5
end
function c210555555.spfilter2(c)
	return not c:IsRace(RACE_MACHINE)
end
function c210555555.spcon(e,c)
	if c == nil then return true end
	return Duel.IsExistingMatchingCard(c210555555.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(c210555555.spfilter2,c:GetControler(),LOCATION_MZONE,0,1,nil) 
end
--summon restriction 
function c210555555.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c210555555.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c210555555.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end 
function c210555555.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end

--move
function c210555555.filter(c)
	returnc:GetRank()==5
end
function c210555555.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c210555555.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210555555.filter,tp,LOCATION_MZONE,0,1,nil)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210555555,0))
	Duel.SelectTarget(tp,c210555555.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c210555555.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0)then return end
	local seq=tc:GetSequence()
	Duel.Hint(HINT_SELECTMSG,tp,571)
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	Duel.MoveSequence(tc,nseq)
end

--add move effect
function c210555555.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function c210555555.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(63394872,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_QUICK_O)
	e1:SetCountLimit(1,210555555+200)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCost(c210555555.mvcost)
	e1:SetTarget(c210555555.mvtg)
	e1:SetOperation(c210555555.mvop)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		rc:RegisterEffect(e2,true)
	end
end
--[[function c210555555.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end]]
function c210555555.mvfilter(c)
	if not c:IsType(TYPE_XYZ) then return false end
	local p=c:GetControler()
	return Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL)>0
end
function c210555555.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(c210555555.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(210555555,2))
	Duel.SelectTarget(tp,c210555555.mvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c210555555.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local p=tc:GetControler()
	if Duel.GetLocationCount(p,LOCATION_MZONE,p,LOCATION_REASON_CONTROL)>0 then
		local s=0
		if tc:IsControler(tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0,true)
		else
			--[[local flag=0
			 for i=0,6 do
			 if Duel.CheckLocation(1-tp,LOCATION_MZONE,i) then flag=bit.bor(flag,math.pow(2,i)) end
			end
			if flag==0 then return end]]
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			-- s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag,true)/0x10000
			s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0,true)/0x10000
		end
		local nseq=math.log(s,2)
		Duel.MoveSequence(tc,nseq)
	end
end
