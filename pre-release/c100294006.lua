--ヴァレット・コーダー
--Rokket Coder
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Treated as a Dragon for the Link Summon of a "Borrel" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetOperation(s.chngcon)
	e1:SetValue(RACE_DRAGON)
	c:RegisterEffect(e1)
	--Can use this as material from your hand for a "Code Talker"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon1)
	e2:SetValue(s.extraval1)
	c:RegisterEffect(e2)
	if s.flagmap1==nil then
		s.flagmap1={}
	end
	if s.flagmap1[c]==nil then
		s.flagmap1[c] = {}
	end
	--Can use 1 DARK monster in your hand as material when using this for a "Borrel" monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon2)
	e3:SetValue(s.extraval2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		s.flagmap2={}
	end)
end
s.listed_series={SET_BORREL,SET_CODE_TALKER}
function s.chngcon(scard,sumtype,tp)
	return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK and scard:IsSetCard(SET_BORREL)
end
function s.extrafilter1(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon1(c,e,tp,sg,mg,lc,og,chk)
	return (sg+mg):Filter(s.extrafilter1,nil,e:GetHandlerPlayer()):IsExists(Card.IsRace,1,og,RACE_CYBERSE) and
	sg:FilterCount(s.flagcheck1,nil)<2
end
function s.flagcheck1(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval1(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(0x101) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap1[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap1[c]) do
			eff:Reset()
		end
		s.flagmap1[c]={}
	end
end
function s.eftg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeLinkMaterial()
end
function s.extrafilter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon2(c,e,tp,sg,mg,lc,og,chk)
	local ct=sg:FilterCount(s.flagcheck2,nil)
	return ct==0 or ((sg+mg):Filter(s.extrafilter2,nil,e:GetHandlerPlayer()):IsExists(Card.IsCode,1,og,id) and ct<2)
end
function s.flagcheck2(c)
	return c:GetFlagEffect(id+100)>0
end
function s.extraval2(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(SET_BORREL) or Duel.GetFlagEffect(tp,id+100)>0 then
			return Group.CreateGroup()
		else
			s.flagmap2[c]=c:RegisterFlagEffect(id+100,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 and Duel.GetFlagEffect(tp,id+100)==0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap2[c] then
			s.flagmap2[c]:Reset()
			s.flagmap2[c]=nil
		end
	end
end