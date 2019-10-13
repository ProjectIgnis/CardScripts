--狂進化
--Crazy Evolution
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x11a}
function s.filter1(c,e,tp)
	local lv=c:GetLevel()
	local rc=c:GetRace()
	return lv>0 and c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,nil,lv,rc,e,tp)
end
function s.filter2(c,lv,rc,e,tp)
	return c:IsLevel(lv) and c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:GetRace()~=rc or Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_MZONE,0,1,nil,rc))
end
function s.filter3(c,rc)
	return c:GetRace()~=rc
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),tc:GetRace(),e,tp)
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		Duel.BreakEffect()
		local tg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local tgc=tg:GetFirst()
		while tgc do
			if not tgc:IsRace(tc:GetRace()) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(tc:GetRace())
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tgc:RegisterEffect(e1)
			end
			tgc=tg:GetNext()
		end
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(tc)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	e:GetHandler():RegisterEffect(e2)
end
function s.dfilter(c,r,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst()~=e:GetLabelObject() then return end
	return eg:IsExists(s.dfilter,1,nil,r,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
