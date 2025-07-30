--Ｙｕｍ☆Ｙｕｍ☆ヤミーズ
--Yum☆Yum☆Yummys
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Each time 2 or more "Yummy" monsters are Special Summoned to your field at the same time, gain 500 LP, and if you do, your opponent pays 500 LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.lpcon)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	--Send 2 face-up monsters, including "Yummy★Snatchy", from the field to the GY, and if you do, Special Summon 1 "Yummy" Synchro Monster from your Extra Deck (this is treated as a Synchro Summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.PayLP(500))
	e2:SetTarget(s.syncsptg)
	e2:SetOperation(s.syncspop)
	c:RegisterEffect(e2)
	--Immediately after this effect resolves, Link Summon 1 "Yummy" Link Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e3:SetCost(Cost.PayLP(100))
	e3:SetTarget(s.linksptg)
	e3:SetOperation(s.linkspop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_YUMMY}
s.listed_names={30581601} --"Yummy★Snatchy"
function s.lpconfilter(c,tp)
	return c:IsSetCard(SET_YUMMY) and c:IsFaceup() and c:IsControler(tp)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lpconfilter,2,nil,tp)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		Duel.Hint(HINT_CARD,0,id)
		if Duel.Recover(tp,500,REASON_EFFECT)>0 then
			Duel.PayLPCost(1-tp,500)
		end
	else
		--Gain 500 LP, and if you do, your opponent pays 500 LP (at the end of the current Chain Link)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetOperation(function(e,tp)
					Duel.Hint(HINT_CARD,0,id)
					if Duel.Recover(tp,500,REASON_EFFECT)>0 then
						Duel.PayLPCost(1-tp,500)
					end
				end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and c:IsAbleToGrave()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,30581601) and Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.syncfilter(c,e,tp,sg)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_SYNCHRO)
	return #pg<=0 and c:IsSetCard(SET_YUMMY) and c:IsSynchroMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
function s.syncsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syncspop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 and Duel.SendtoGrave(tg,REASON_EFFECT)==2 and tg:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		sc:SetMaterial(nil)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end
function s.linkfilter(c)
	return c:IsSetCard(SET_YUMMY) and c:IsLinkSummonable()
end
function s.linksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.LinkSummon(tp,sc)
	end
end