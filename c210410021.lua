--created & coded by Lyris, art by Sinad Jaruartjanapat
--天剣主女王十
function c210410021.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xfb2),2,2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c210410021.val)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetOperation(c210410021.op)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(function(e) local c=e:GetHandler() local rc=re:GetHandler() if c:GetFlagEffect(210410021)==0 and re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0xfb2) and c:GetLinkedGroup():IsContains(rc) then c:RegisterFlagEffect(210410021,RESET_EVENT+0x1fe0000,0,1) end end)
	c:RegisterEffect(e3)
end
function c210410021.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb2)
end
function c210410021.val(e)
	return Duel.GetMatchingGroupCount(c210410021.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end
function c210410021.filter(c,e,tp)
	return c:IsSetCard(0xfb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or ((Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp))))
end
function c210410021.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c210410021.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if c:GetFlagEffect(210410021)==0 or g:GetCount()==0
		or not Duel.SelectEffectYesNo(tp,c) then
		c:ResetFlagEffect(210410021)
		e:SetCountLimit(e:GetCountLimit()+1)
		return
	end
	c:ResetFlagEffect(210410021)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(210410021,0),aux.Stringid(210410021,1))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(210410021,0))
		elseif b2 then
			op=Duel.SelectOption(tp,aux.Stringid(210410021,1))+1
		else return end
		Duel.Hint(HINT_CARD,0,210410021)
		local p=tp
		if op~=0 then p=1-p end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP_DEFENSE)
	end
end
