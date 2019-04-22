--Bessonth, the Doom Dragon
--2017 edo9300
function c210004000.initial_effect(c)
	c:SetSPSummonOnce(210004000)
	--xyz summon
	Auxiliary.AddFusionProcMix(c,false,false,c210004000.fil2,aux.NonTuner(c210004000.fil))
	aux.AddSynchroProcedure(c,c210004000.fil,1,1,aux.NonTunerEx(c210004000.fil),1,1)
	aux.AddXyzProcedure(c,c210004000.fil,nil,2,nil,nil,nil,nil,true,c210004000.xyzcheck)
	c:EnableReviveLimit()
	--splimit
	local lm=Effect.CreateEffect(c)
	lm:SetType(EFFECT_TYPE_FIELD)
	lm:SetRange(LOCATION_PZONE)
	lm:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	lm:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	lm:SetTargetRange(1,0)
	lm:SetTarget(c210004000.splimit)
	c:RegisterEffect(lm)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--level/rank
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0a:SetCode(EFFECT_RANK_LEVEL)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_ALLOW_NEGATIVE)
	c:RegisterEffect(e0b)
	--Adjust Level/Rank
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetCode(EFFECT_CHANGE_LEVEL)
	e0c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0c:SetRange(LOCATION_MZONE)
	e0c:SetCondition(function(e)return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)end)
	e0c:SetValue(0)
	c:RegisterEffect(e0c)
	--
	local e0d=Effect.CreateEffect(c)
	e0d:SetType(EFFECT_TYPE_SINGLE)
	e0d:SetCode(EFFECT_CHANGE_RANK)
	e0d:SetCondition(function(e)return not e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)end)
	e0d:SetValue(0)
	c:RegisterEffect(e0d)
	--Recover ATK
	local lp=Effect.CreateEffect(c)
	lp:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	lp:SetCode(EVENT_SPSUMMON_SUCCESS)
	lp:SetCondition(c210004000.lpcon)
	lp:SetOperation(c210004000.lpop)
	c:RegisterEffect(lp)
	--Damage LV/RK
	local dam=lp:Clone()
	dam:SetCondition(c210004000.dmcon)
	dam:SetOperation(c210004000.dmop)
	c:RegisterEffect(dam)
	--Gain Xyz's ATK/DEF
	local ad=lp:Clone()
	ad:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	ad:SetCondition(c210004000.adcon)
	ad:SetOperation(c210004000.adop)
	c:RegisterEffect(ad)
	--Return/pzone
	local ret=Effect.CreateEffect(c)
	ret:SetCategory(CATEGORY_TODECK)
	ret:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	ret:SetCode(EVENT_PHASE+PHASE_END)
	ret:SetRange(LOCATION_MZONE)
	ret:SetCountLimit(1)
	ret:SetCondition(c210004000.retcon)
	ret:SetTarget(c210004000.rettg)
	ret:SetOperation(c210004000.retop)
	c:RegisterEffect(ret)
	local mov=ret:Clone()
	mov:SetCondition(c210004000.pencon)
	mov:SetTarget(c210004000.pentg)
	mov:SetOperation(c210004000.penop)
	c:RegisterEffect(mov)
	--Win
	local win=Effect.CreateEffect(c)
	win:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	win:SetCode(EVENT_CUSTOM+210004000)
	win:SetRange(LOCATION_PZONE)
	win:SetTarget(c210004000.wtg)
	win:SetOperation(c210004000.wop)
	c:RegisterEffect(win)
	if c210004000.global_check==nil then
		c210004000.global_check=true
		for i=0,1 do
			c210004000[i]={}
			c210004000[i][SUMMON_TYPE_FUSION]=false
			c210004000[i][SUMMON_TYPE_SYNCHRO]=false
			c210004000[i][SUMMON_TYPE_XYZ]=false
		end
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(c210004000.sumop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c210004000.fil(...)
    	local c,val,sc,sumtype,tp,g
    	local t={...}
    	if type(t[3])=='number' then
        	c,sc,sumtype,tp=table.unpack(t)
    	else
        	c,val,sc,sumtype,tp=table.unpack(t)
    	end
    	return c:IsLevel(6) and c:IsLocation(LOCATION_ONFIELD) and c:IsRace(RACE_DRAGON,sc,sumtype,tp)
end
function c210004000.fil2(c,sc,sumtype,tp)
	return c:IsLevel(6) and c:IsLocation(LOCATION_ONFIELD) and c:IsRace(RACE_DRAGON,sc,sumtype,tp) and c:IsType(TYPE_TUNER,sc,sumtype,tp)
end
function c210004000.xyzcheck(g,tp,xyz)
    	return g:IsExists(c210004000.xyzchk,1,nil,xyz,SUMMON_TYPE_XYZ,tp,g)
end
function c210004000.xyzchk(c,xyz,sumtype,tp,g)
    	return c:IsType(TYPE_TUNER,xyz,SUMMON_TYPE_XYZ,tp) and g:IsExists(aux.NOT(Card.IsType),1,c,TYPE_TUNER,xyz,SUMMON_TYPE_XYZ,tp)
end
function c210004000.sumop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:GetOriginalCode()==e:GetHandler():GetOriginalCode() then 
			if tc:IsSummonType(SUMMON_TYPE_FUSION) then
				c210004000[tc:GetSummonPlayer()][SUMMON_TYPE_FUSION]=true
			end
			if tc:IsSummonType(SUMMON_TYPE_SYNCHRO) then
				c210004000[tc:GetSummonPlayer()][SUMMON_TYPE_SYNCHRO]=true
			end
			if tc:IsSummonType(SUMMON_TYPE_XYZ) then
				c210004000[tc:GetSummonPlayer()][SUMMON_TYPE_XYZ]=true
			end
		end
	end
end
function c210004000.splimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c210004000.sucop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) then
		local e0c=Effect.CreateEffect(c)
		e0c:SetType(EFFECT_TYPE_SINGLE)
		e0c:SetCode(EFFECT_CHANGE_LEVEL)
		e0c:SetReset(RESET_EVENT+0x1fd0000)
		e0c:SetValue(0)
		c:RegisterEffect(e0c)
	else
		local e0d=Effect.CreateEffect(c)
		e0d:SetType(EFFECT_TYPE_SINGLE)
		e0d:SetCode(EFFECT_CHANGE_RANK)
		e0d:SetReset(RESET_EVENT+0x1fd0000)
		e0d:SetValue(0)
		c:RegisterEffect(e0d)
	end
end
function c210004000.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c210004000.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(e:GetHandlerPlayer(),Duel.GetMatchingGroup(Card.IsType,0,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_MONSTER):GetSum(Card.GetAttack),REASON_EFFECT)
end
function c210004000.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c210004000.dmcardfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c210004000.dmfilter(c)
	return (c:GetLevel()+c:GetRank())*200
end
function c210004000.dmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-e:GetHandlerPlayer(),Duel.GetMatchingGroup(c210004000.dmcardfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler()):GetSum(c210004000.dmfilter),REASON_EFFECT)
end
function c210004000.adfilter(c)
	return c:IsType(TYPE_XYZ) and not c:IsCode(210004000)
end
function c210004000.adcost(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingMatchingCard(c210004000.adfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil) end
	local g=e:GetHandler():GetOverlayGroup()
	Duel.SendtoGrave(g,REASON_COST)
end
function c210004000.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function c210004000.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	if Duel.SendtoGrave(g,REASON_COST)~=0 and Duel.IsExistingMatchingCard(c210004000.adfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cg=Duel.SelectMatchingCard(tp,c210004000.adfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,1,nil)
		if cg:GetCount()==0 then return end
		Duel.ConfirmCards(1-tp,cg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(cg:GetFirst():GetAttack())
		e1:SetReset(RESET_EVENT+0x1ff0000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetValue(cg:GetFirst():GetDefense())
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
function c210004000.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c210004000[c:GetOwner()][SUMMON_TYPE_FUSION]==false or c210004000[c:GetOwner()][SUMMON_TYPE_SYNCHRO]==false or c210004000[c:GetOwner()][SUMMON_TYPE_XYZ]==false
end
function c210004000.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c210004000.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
end
function c210004000.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c210004000[c:GetOwner()][SUMMON_TYPE_FUSION]==true and c210004000[c:GetOwner()][SUMMON_TYPE_SYNCHRO]==true and c210004000[c:GetOwner()][SUMMON_TYPE_XYZ]==true
end
function c210004000.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if g then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
function c210004000.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(c:GetOwner(),LOCATION_PZONE,0)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if c:IsRelateToEffect(e) then
		if Duel.MoveToField(c,c:GetOwner(),c:GetOwner(),LOCATION_PZONE,POS_FACEUP,true)~=0 then
			Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+210004000,e,0,0,0,0)
		end
	end
end
function c210004000.wtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c210004000.wop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(e:GetHandler():GetOwner(),0x100)
end
