--オーバーハンドレッド・カオス・ユニバース
--Chaos Hundred Universe
--Updated by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DESTROY+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--global check
	aux.GlobalCheck(s,function()
	--gather all destroyed c10x
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_DESTROYED)
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	--empty gg during EP
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge2:SetCode(EVENT_PHASE+PHASE_END)
	ge2:SetCountLimit(1,id)
	ge2:SetOperation(s.empty)
	Duel.RegisterEffect(ge2,0)
	end)
	gg=Group.CreateGroup()
	gg:KeepAlive()
end

s.listed_series={0x1048}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
	local class=tc:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	if tc:IsSetCard(0x1048) and tc:IsType(TYPE_MONSTER) and tc:GetControler()==tc:GetPreviousControler() and no and no>=101 and no<=107 then
		gg:AddCard(tc)
	end
	end
end

function s.filter(c,e,tp,ct)
	local class=c:GetMetatable()
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(0x1048)
		and Duel.GetLocationCountFromEx(1-tp,tp,nil,c)>=ct
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=gg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsCanBeSpecialSummoned,nil,e,tp,false,false,POS_FACEUP)
	local ct=#g
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and (not ect or ect>=ct)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,ct,nil,e,tp,ct)
		and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ct<2) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,ct,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=gg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):Filter(Card.IsCanBeSpecialSummoned,nil,e,tp,false,false,POS_FACEUP)
	if #g1>0 then
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,#g1,#g1,nil,e,tp,#g1)
		if #g2>0 then
		Duel.SpecialSummon(g2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	g1:Merge(g2)
	for tc in aux.Next(g1) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	 s.empty(e,tp,eg,ep,ev,re,r,rp)	
end

function s.empty(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(gg) do
	gg:RemoveCard(tc)
    end
end