--Wicked Cradle
function c210660008.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c210660008.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	--banish
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31755044,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c210660008.rmcon)
	e4:SetTarget(c210660008.rmtg)
	e4:SetOperation(c210660008.rmop)
	c:RegisterEffect(e4)
	--indestructable
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetValue(c210660008.indesval)
	c:RegisterEffect(e5)
	--cannot set
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_MSET)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(0,1)
	e6:SetCondition(c210660008.setcon)
	e6:SetTarget(aux.TRUE)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e7)
	local e8=e6:Clone()
	e8:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e8)
	local e9=e6:Clone()
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e9:SetTarget(c210660008.sumlimit)
	c:RegisterEffect(e9)
	--recover
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	ea:SetCategory(CATEGORY_RECOVER)
	ea:SetDescription(aux.Stringid(28106077,0))
	ea:SetCode(EVENT_BATTLE_DAMAGE)
	ea:SetRange(LOCATION_SZONE)
	ea:SetCondition(c210660008.reccon)
	ea:SetTarget(c210660008.rectg)
	ea:SetOperation(c210660008.recop)
	c:RegisterEffect(ea)
	--special summon
	local eb=Effect.CreateEffect(c)
	eb:SetCategory(CATEGORY_SPECIAL_SUMMON)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	eb:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	eb:SetRange(LOCATION_FZONE)
	eb:SetCode(EVENT_TO_GRAVE)
	eb:SetCondition(c210660008.spcon)
	eb:SetTarget(c210660008.sptg)
	eb:SetOperation(c210660008.spop)
	c:RegisterEffect(eb)
end
function c210660008.target(e,c)
	return c:IsLevelAbove(10) and c:IsRace(RACE_FIEND)
end
function c210660008.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	e:SetLabelObject(des)
	e:SetLabel(rc:GetControler())
	return des:IsLocation(LOCATION_GRAVE) and des:IsType(TYPE_MONSTER) and rc:IsRelateToBattle() and rc:IsLevelAbove(10)
end
function c210660008.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
function c210660008.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	local sp=e:GetLabel()
	if not bc:IsLocation(LOCATION_REMOVED) and Duel.SelectEffectYesNo(sp,e:GetHandler()) then
		if Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.Recover(sp,500,REASON_EFFECT)
		end
	end
end
function c210660008.indesval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function c210660008.avfilter(c)
	return c:IsCode(21208154) and c:IsFaceup()
end
function c210660008.setcon(e)
	local tp=e:GetHandler():GetControler()
	return Duel.IsExistingMatchingCard(c210660008.avfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210660008.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
function c210660008.drfilter(c)
	return c:IsCode(62180201) and c:IsFaceup()
end
function c210660008.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210660008.drfilter,tp,LOCATION_MZONE,0,1,nil) and ep~=tp
end
function c210660008.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
function c210660008.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function c210660008.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=nil
	for tc in aux.Next(eg) do
		if tc:IsReason(REASON_DESTROY) and tc:IsCode(57793869) and not tc:IsPreviousLocation(LOCATION_SZONE) then
			c=tc
		end
	end
	return c
end
function c210660008.spfilter(c,e,tp)
	return c:IsCode(57793869) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c210660008.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and not (Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2)
		and Duel.IsExistingMatchingCard(c210660008.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,65810490,0xf66,0x4011,1000,1000,4,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function c210660008.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210660008.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 
			and not Duel.IsPlayerAffectedByEffect(tp,59822133) 
			and not (Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<2) 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,65810490,0xf66,0x4011,1000,1000,4,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then
			for i=1,2 do
				local token=Duel.CreateToken(tp,65810490)
				Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end