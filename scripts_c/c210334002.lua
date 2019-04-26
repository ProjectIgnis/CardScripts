--Supreme King Dragon Starwurm
--inspired by Eerie Code
--designed and scripted by Larry126
function c210334002.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--pendulum set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69610326,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c210334002.pccon)
	e1:SetTarget(c210334002.pctg)
	e1:SetOperation(c210334002.pcop)
	c:RegisterEffect(e1)
	--Atk change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(function(e,c) return Duel.GetMatchingGroupCount(c210334002.atkfilter1,e2:GetHandlerPlayer(),LOCATION_EXTRA,0,nil)*100 end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(function(e,c) return Duel.GetMatchingGroupCount(c210334002.atkfilter2,e3:GetHandlerPlayer(),LOCATION_EXTRA,0,nil)*-100 end)
	c:RegisterEffect(e3)
	--pendulum xyz
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69610326,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,210334002)
	e4:SetTarget(c210334002.sctg)
	e4:SetOperation(c210334002.scop)
	c:RegisterEffect(e4)
end
function c210334002.atkfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf8) and not c:IsRace(RACE_DRAGON)
end
function c210334002.atkfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf8) and c:IsRace(RACE_DRAGON)
end
function c210334002.scfilter1(c,tp,mc)
	return Duel.IsExistingMatchingCard(c210334002.scfilter2,tp,LOCATION_PZONE,0,1,nil,mc,c)
end
function c210334002.scfilter2(c,mc,sc)
	local mg=Group.FromCards(c,mc)
	c:AssumeProperty(ASSUME_TYPE,c:GetOriginalType())
	return c:IsCanBeXyzMaterial(sc) and sc:IsXyzSummonable(mg,2,2)
		and sc:IsType(TYPE_XYZ) and sc:IsRace(RACE_DRAGON) and sc:IsAttribute(ATTRIBUTE_DARK)
end
function c210334002.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,c)>0
		and Duel.IsExistingMatchingCard(c210334002.scfilter1,tp,LOCATION_EXTRA,0,1,nil,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c210334002.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end
	local g=Duel.GetMatchingGroup(c210334002.scfilter1,tp,LOCATION_EXTRA,0,nil,tp,c)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local mg=Duel.SelectMatchingCard(tp,c210334002.scfilter2,tp,LOCATION_PZONE,0,1,1,nil,c,sc)
		mg:AddCard(c)
		Duel.XyzSummon(tp,sc,mg)
	end
end
function c210334002.pccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function c210334002.pcfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c210334002.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c210334002.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c210334002.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c210334002.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c210334002.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c210334002.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
