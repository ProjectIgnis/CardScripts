--オルターガイスト・プークエリ (Anime)
--Altergeist Pookuery (Anime)
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Extra Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,alias)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	--salvage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,alias+1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x103}
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return (sg+mg):Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsSetCard,og,1,0x103) and
	#(sg&sg:Filter(s.flagcheck,nil))<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(alias)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if not summon_type==SUMMON_TYPE_LINK or not sc:IsSetCard(0x103) or Duel.GetFlagEffect(tp,alias)>0 then
			return Group.CreateGroup()
		else
			local feff=c:RegisterFlagEffect(alias,0,0,1)
			local eff=Effect.CreateEffect(c)
			eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			eff:SetCode(EVENT_ADJUST)
			eff:SetOperation(function(e)feff:Reset() e:Reset() end)
			Duel.RegisterEffect(eff,0)
			return Group.FromCards(c)
		end
	else
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,alias)
			Duel.RegisterFlagEffect(tp,alias,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x103) and c:IsLinkMonster() and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
