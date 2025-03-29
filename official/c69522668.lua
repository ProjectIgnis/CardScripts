--魔鍵変鬼－トランスフルミネ
--Magikey Fiend - Transfurlmine
--scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MAGIKEY),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_NORMAL),1,99)
	c:EnableReviveLimit()
	--Make up to 2 attacks on monsters each Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Check materials' attributes before summoning
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetCode(EFFECT_MATERIAL_CHECK)
	e2a:SetValue(s.matcheck)
	c:RegisterEffect(e2a)
	--Set 1 Magikey S/T from Deck to S/T Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetLabelObject(e2a)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Destroy a NS/SSd monster with the same Att as monsters in your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAGIKEY}
function s.matcheck(e,c)
	e:SetLabel(c:GetMaterial():GetClassCount(Card.GetAttribute))
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local obj=e:GetLabelObject()
	return e:GetHandler():IsSynchroSummoned() and obj and obj:GetLabel()>1
end
function s.setfilter(c)
	return c:IsSetCard(SET_MAGIKEY) and c:IsSpellTrap() and not c:IsType(TYPE_FIELD) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc)
	end
end
function s.get_attr(tp)
	local att=0
	for tc in Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil):Iter() do
		att=att|tc:GetAttribute()
	end
	return att
end
function s.desfilter(c,tp,att)
	return c:IsSummonPlayer(1-tp) and c:GetAttribute()&att>0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local att=s.get_attr(tp)
	return eg:IsExists(s.desfilter,1,nil,tp,att)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(s.desfilter,nil,tp,s.get_attr(tp))
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,tp,s.get_attr(tp)):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end