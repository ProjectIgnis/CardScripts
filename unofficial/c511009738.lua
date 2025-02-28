--リンク・リカバリー
--Link Recovery
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_GRAVE)
	local ct=tc:GetLink()-Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)
	if ct>0 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,ct)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local ct=tc:GetLink()-Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)
		if ct>0 then
			Duel.Draw(1-tp,ct,REASON_EFFECT)
		end
		local c=e:GetHandler()
		--You cannot conduct your Battle Phase the turn the Special Summoned monster is used as material for a Link Summon
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EVENT_BE_MATERIAL)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r==REASON_LINK end)
		e1:SetOperation(s.cannotbpop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_TOGRAVE|RESET_REMOVE|RESET_LEAVE))
		tc:RegisterEffect(e1,true)
		--This card cannot be used as material for a Link Summon the turn that you conduct your Battle Phase
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e2:SetCondition(function() return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)>0 end)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
function s.cannotbpop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	--You cannot conduct your Battle Phase this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end