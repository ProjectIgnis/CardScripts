--凶導の白き天底
--White Zoa of Dogmatika
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be special summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.ritlimit)
	c:RegisterEffect(e1)
	--Unaffected by activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DOGMATIKA))
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.unaval)
	c:RegisterEffect(e2)
	--Your opponent applies 1 effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.applytg)
	e3:SetOperation(s.applyop)
	c:RegisterEffect(e3)
end
s.listed_names={31002402}
s.listed_series={SET_DOGMATIKA}
function s.ritlimit(e,se,sp,st)
	if (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL then
		return se:GetHandler():IsSetCard(SET_DOGMATIKA)
	end
	return true
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() 
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() 
		and te:IsActiveType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ex_ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local b1=ex_ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,ex_ct//2,nil)
	local texg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK),tp,0,LOCATION_MZONE,nil)
	local b2=#texg>0 and #texg==texg:FilterCount(Card.IsAbleToExtra,nil)
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,1-tp,LOCATION_MZONE)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local ex_ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local b1=ex_ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,ex_ct//2,nil)
	local texg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK),tp,0,LOCATION_MZONE,nil)
	local b2=#texg>0 and #texg==texg:FilterCount(Card.IsAbleToExtra,nil)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(1-tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		local send_ct=ex_ct//2
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,send_ct,send_ct,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif op==2 then
		texg:Match(Card.IsAbleToExtra,nil)
		Duel.SendtoDeck(texg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end