--拘束解除
--Front Change
--Re-scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Summon "Assault Cannon Beetle"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.hint)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg(511000111,511000110))
	e1:SetOperation(s.op(511000111,511000110))
	c:RegisterEffect(e1)
	--Summon "Combat Scissor Beetle"
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetTarget(s.tg(511000110,511000111))
	e2:SetOperation(s.op(511000110,511000111))
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=Group.CreateGroup()
		s[1]:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetOperation(s.checkop)
		Duel.RegisterEffect(ge3,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]:Clear()
		end)
	end)
end
s.listed_names={511000110,511000111}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if not s[0] and tc:IsFaceup() and tc:IsCode(511000110) then
			if s[1]:IsContains(tc) then s[0]=true
			else s[1]:AddCard(tc) end
		end
	end
end
function s.hint(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.confilter(c,g)
	return g:IsExists(Card.IsCode,1,nil,511000110)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return s[0] or not s[1]:IsExists(s.confilter,1,nil,s[1])
end
function s.tefilter(c,e,tp,code1,code2)
	return c:IsCode(code1) and c:IsAbleToExtra() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,code2)
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.tg(code1,code2)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_MZONE,0,1,nil,e,tp,code1,code2) end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.op(code1,code2)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local te=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,code1,code2)
		if #te>0 and Duel.SendtoDeck(te,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sp=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code2)
			if #sp>0 then
				Duel.SpecialSummon(sp,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end