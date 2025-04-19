--Get Your Game On!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
s.illegal=true
s.listes_series={SET_ELEMENTAL_HERO,SET_NEO_SPACIAN}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dl=6
	while dl==6 do
		dl=Duel.TossDice(tp,1)
	end
	local op=0
	local proof=true
	if dl==1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
		if op~=0 then
			proof=false
		end
	end
	if dl==2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6),aux.Stringid(id,7))
		if op~=1 then
			proof=false
		end
	end
	if dl==3 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,8))
		op=Duel.SelectOption(tp,aux.Stringid(id,9),aux.Stringid(id,10),aux.Stringid(id,3))
		if op~=0 then
			proof=false
		end
	end
	if dl==4 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,11))
		local mon=Duel.AnnounceNumber(tp,1,2,3,4,5,6,7,8,9,10,11,12)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,12))
		local day=Duel.AnnounceNumber(tp,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31)
		if mon~=7 or day~=28 then
			proof=false
		end
	end
	if dl==5 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,13))
		op=Duel.AnnounceCard(tp)
		if op~=501000006 and op~=501000007 and op~=501000004 then
			proof=false
		end
	end
	if proof==false then
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_RULE)
	end
end
function s.atktg(e,c)
	return c:IsSetCard(SET_ELEMENTAL_HERO) or c:IsSetCard(SET_NEO_SPACIAN)
end
function s.val(e,c)
	return c:GetAttack()*2
end