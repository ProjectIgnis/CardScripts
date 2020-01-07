--Extra Shave Reborn
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--the effect
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PREDRAW)
		ge1:SetCountLimit(1)
		ge1:SetOperation(s.gop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.gop(e,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,0,0,0)
		tc=g:GetNext()
	end
end
function s.prefilter(c,tp)
	return c:IsPreviousControler(tp) and (c:GetPreviousTypeOnField()&TYPE_MONSTER)==TYPE_MONSTER and c:GetLevel()>0 
		and c:GetFlagEffect(id)~=0
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	local cg=eg:Filter(s.prefilter,nil,tp)
	local rg,lv=cg:GetMaxGroup(Card.GetLevel)
	e:SetLabel(lv)
	return #cg>0
end
function s.filter(c,e,tp,lv)
	return c:GetFlagEffect(id)~=0 and c:GetLevel()<lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not (c:IsType(TYPE_XYZ) and not (c:IsHasEffect(EFFECT_RANK_LEVEL) or c:IsHasEffect(EFFECT_RANK_LEVEL_S)))
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	local lv=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,lv) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,0,0)
end
function s.activate(e,tp,eg,ev,ep,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
